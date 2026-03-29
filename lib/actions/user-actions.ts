"use server";

import { db } from "@/lib/db";
import { member, instructor, user } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";

export async function updateMember(
  memberId: number,
  data: {
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    address?: string;
    dob?: string;
    healthInfo?: string;
  }
) {
  await requireRole(["manager"]);

  await db
    .update(member)
    .set({
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      phone: data.phone,
      address: data.address || null,
      dob: data.dob || null,
      healthInfo: data.healthInfo || null,
    })
    .where(eq(member.id, memberId));

  revalidatePath("/users/members");
  revalidatePath(`/users/members/${memberId}`);
  return { success: true };
}

export async function updateInstructor(
  instructorId: number,
  data: {
    title: string;
    firstName: string;
    lastName: string;
    position: string;
    phone: string;
    email: string;
    profile?: string;
  }
) {
  await requireRole(["manager"]);

  await db
    .update(instructor)
    .set({
      title: data.title,
      firstName: data.firstName,
      lastName: data.lastName,
      position: data.position,
      phone: data.phone,
      email: data.email,
      profile: data.profile || null,
    })
    .where(eq(instructor.id, instructorId));

  revalidatePath("/users/instructors");
  revalidatePath(`/users/instructors/${instructorId}`);
  return { success: true };
}

export async function deactivateUser(userId: string) {
  await requireRole(["manager"]);

  await db
    .update(user)
    .set({ isActive: false })
    .where(eq(user.id, userId));

  revalidatePath("/users/members");
  revalidatePath("/users/instructors");
  return { success: true };
}

export async function changeUserRole(
  userId: string,
  role: "member" | "instructor" | "manager"
) {
  await requireRole(["manager"]);

  await db
    .update(user)
    .set({ role })
    .where(eq(user.id, userId));

  revalidatePath("/users/members");
  revalidatePath("/users/instructors");
  return { success: true };
}
