// Supabase Edge Function: cashfree-refund
// Issues a refund for a Cashfree order
// Deploy: supabase functions deploy cashfree-refund

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const CASHFREE_APP_ID = Deno.env.get("CASHFREE_APP_ID")!;
const CASHFREE_SECRET_KEY = Deno.env.get("CASHFREE_SECRET_KEY")!;
const CASHFREE_ENV = Deno.env.get("CASHFREE_ENV") ?? "SANDBOX";

const CASHFREE_BASE_URL =
  CASHFREE_ENV === "PRODUCTION"
    ? "https://api.cashfree.com/pg"
    : "https://sandbox.cashfree.com/pg";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const { order_id, refund_amount, reason } = await req.json();

    const cashfreeRes = await fetch(
      `${CASHFREE_BASE_URL}/orders/${order_id}/refunds`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-version": "2023-08-01",
          "x-client-id": CASHFREE_APP_ID,
          "x-client-secret": CASHFREE_SECRET_KEY,
        },
        body: JSON.stringify({
          refund_amount,
          refund_id: `refund-${Date.now()}`,
          refund_note: reason ?? "Customer request",
        }),
      }
    );

    if (!cashfreeRes.ok) {
      const err = await cashfreeRes.text();
      return new Response(
        JSON.stringify({ error: "Refund failed", details: err }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    const data = await cashfreeRes.json();

    // Update booking
    await supabaseClient
      .from("bookings")
      .update({
        payment_status: data.refund_status === "SUCCESS" ? "refunded" : "paid",
        refund_amount: refund_amount,
        refunded_at: new Date().toISOString(),
        escrow_status: "refunded",
      })
      .eq("cashfree_order_id", order_id);

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Internal error", message: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
