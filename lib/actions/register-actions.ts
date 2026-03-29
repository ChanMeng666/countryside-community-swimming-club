"use server";

import { db } from "@/lib/db";
import { member } from "@/lib/db/schema";

export async function createMemberProfile(data: {
  userId: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
}) {
  await db.insert(member).values({
    userId: data.userId,
    firstName: data.firstName,
    lastName: data.lastName,
    email: data.email,
    phone: data.phone,
    membershipType: "None",
    isSubscription: false,
  });

  return { success: true };
}
