import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { member } from "@/lib/db/schema";
import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  const body = await request.json();
  const { email, password, firstName, lastName, phone } = body;

  // Create auth user via Better Auth
  const result = await auth.api.signUpEmail({
    body: {
      email,
      password,
      name: `${firstName} ${lastName}`,
    },
  });

  if (!result?.user?.id) {
    return NextResponse.json(
      { error: "Registration failed" },
      { status: 400 }
    );
  }

  // Create member profile
  try {
    await db.insert(member).values({
      userId: result.user.id,
      firstName,
      lastName,
      email,
      phone: phone || "",
      membershipType: "None",
      isSubscription: false,
    });
  } catch (e) {
    // Member profile creation failed, but user exists.
    // This is acceptable — admin can create profile later.
    console.error("Failed to create member profile:", e);
  }

  return NextResponse.json({ success: true, user: result.user });
}
