// Supabase Edge Function: cashfree-create-order
// Creates a Cashfree order for the user
// Deploy: supabase functions deploy cashfree-create-order

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const CASHFREE_APP_ID = Deno.env.get("CASHFREE_APP_ID")!;
const CASHFREE_SECRET_KEY = Deno.env.get("CASHFREE_SECRET_KEY")!;
const CASHFREE_ENV = Deno.env.get("CASHFREE_ENV") ?? "SANDBOX";

const CASHFREE_BASE_URL =
  CASHFREE_ENV === "PRODUCTION"
    ? "https://api.cashfree.com/pg"
    : "https://sandbox.cashfree.com/pg";

interface CreateOrderRequest {
  order_id: string;
  order_amount: number;
  order_currency?: string;
  customer_details: {
    customer_id: string;
    customer_name: string;
    customer_email: string;
    customer_phone: string;
  };
  order_meta?: Record<string, any>;
}

serve(async (req) => {
  // CORS preflight
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
    // Verify authenticated user
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const {
      data: { user },
    } = await supabaseClient.auth.getUser();

    if (!user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const body: CreateOrderRequest = await req.json();

    // Call Cashfree API
    const cashfreeRes = await fetch(`${CASHFREE_BASE_URL}/orders`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-version": "2023-08-01",
        "x-client-id": CASHFREE_APP_ID,
        "x-client-secret": CASHFREE_SECRET_KEY,
      },
      body: JSON.stringify({
        order_id: body.order_id,
        order_amount: body.order_amount,
        order_currency: body.order_currency ?? "INR",
        customer_details: body.customer_details,
        order_meta: {
          ...body.order_meta,
          user_id: user.id,
        },
        order_note: `Rental booking ${body.order_id}`,
      }),
    });

    if (!cashfreeRes.ok) {
      const err = await cashfreeRes.text();
      console.error("Cashfree error:", err);
      return new Response(
        JSON.stringify({ error: "Cashfree order creation failed", details: err }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    const cashfreeData = await cashfreeRes.json();

    return new Response(
      JSON.stringify({
        order_id: cashfreeData.order_id,
        payment_session_id: cashfreeData.payment_session_id,
        order_amount: cashfreeData.order_amount,
        order_currency: cashfreeData.order_currency,
        order_status: cashfreeData.order_status,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (err) {
    console.error("Error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error", message: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
