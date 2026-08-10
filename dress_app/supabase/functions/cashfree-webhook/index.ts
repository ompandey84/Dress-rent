// Supabase Edge Function: cashfree-webhook
// Receives Cashfree payment notifications
// Deploy: supabase functions deploy cashfree-webhook
// Configure webhook URL in Cashfree Dashboard: https://your-app.supabase.co/functions/v1/cashfree-webhook

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const CASHFREE_WEBHOOK_SECRET = Deno.env.get("CASHFREE_WEBHOOK_SECRET")!;

serve(async (req) => {
  try {
    const rawBody = await req.text();
    const signature = req.headers.get("x-cashfree-signature");

    // Verify signature (in production)
    if (signature && CASHFREE_WEBHOOK_SECRET) {
      // Cashfree uses HMAC-SHA256 with the webhook secret
      const encoder = new TextEncoder();
      const key = await crypto.subtle.importKey(
        "raw",
        encoder.encode(CASHFREE_WEBHOOK_SECRET),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"]
      );
      const sig = await crypto.subtle.sign("HMAC", key, encoder.encode(rawBody));
      const expected = Array.from(new Uint8Array(sig))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join("");
      if (expected !== signature) {
        return new Response("Invalid signature", { status: 401 });
      }
    }

    const body = JSON.parse(rawBody);
    console.log("Cashfree webhook:", body);

    // Cashfree webhook types:
    // PAYMENT_STATUS_CHANGED — payment succeeded or failed
    // REFUND_STATUS_CHANGED — refund processed
    const eventType = body.type;
    const data = body.data;

    // Use service role key for webhook (no user auth)
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    if (eventType === "PAYMENT_STATUS_CHANGED") {
      const orderId = data.order.order_id;
      const paymentStatus = data.payment.payment_status;
      const paymentId = data.payment.cf_payment_id;

      if (paymentStatus === "SUCCESS") {
        // Update booking
        await supabaseAdmin
          .from("bookings")
          .update({
            payment_status: "paid",
            status: "pending_lender_acceptance",
            cashfree_payment_id: paymentId,
            escrow_status: "held",
          })
          .eq("cashfree_order_id", orderId);

        // Notify lender of new booking
        const { data: booking } = await supabaseAdmin
          .from("bookings")
          .select("lender_id, renter_id, listing_id, order_number")
          .eq("cashfree_order_id", orderId)
          .single();

        if (booking) {
          await supabaseAdmin.from("notifications").insert({
            user_id: booking.lender_id,
            type: "new_booking",
            title: "New Booking Request",
            body: `You have a new booking ${booking.order_number}. Accept within 4 hours.`,
            related_booking_id: booking.id,
            related_listing_id: booking.listing_id,
            related_user_id: booking.renter_id,
          });
        }
      } else if (paymentStatus === "FAILED") {
        await supabaseAdmin
          .from("bookings")
          .update({
            payment_status: "failed",
            status: "cancelled_by_renter",
          })
          .eq("cashfree_order_id", orderId);
      }
    } else if (eventType === "REFUND_STATUS_CHANGED") {
      const orderId = data.order.order_id;
      const refundStatus = data.refund.refund_status;

      if (refundStatus === "SUCCESS") {
        await supabaseAdmin
          .from("bookings")
          .update({
            payment_status: "refunded",
            escrow_status: "refunded",
            refunded_at: new Date().toISOString(),
          })
          .eq("cashfree_order_id", orderId);
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Webhook error:", err);
    return new Response(
      JSON.stringify({ error: "Internal error", message: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
