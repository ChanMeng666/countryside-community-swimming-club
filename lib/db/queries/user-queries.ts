import { db } from "@/lib/db";
import { member, instructor, user } from "@/lib/db/schema";
import { eq } from "drizzle-orm";

export async function getAllMembers() {
  return db
    .select({
      id: member.id,
      userId: member.userId,
      firstName: member.firstName,
      lastName: member.lastName,
      email: member.email,
      phone: member.phone,
      membershipType: member.membershipType,
      isActive: user.isActive,
    })
    .from(member)
    .innerJoin(user, eq(member.userId, user.id));
}

export async function getMemberById(id: number) {
  const results = await db
    .select({
      id: member.id,
      userId: member.userId,
      firstName: member.firstName,
      lastName: member.lastName,
      email: member.email,
      phone: member.phone,
      address: member.address,
      dob: member.dob,
      healthInfo: member.healthInfo,
      membershipType: member.membershipType,
      expiredDate: member.expiredDate,
      isSubscription: member.isSubscription,
      isActive: user.isActive,
    })
    .from(member)
    .innerJoin(user, eq(member.userId, user.id))
    .where(eq(member.id, id))
    .limit(1);

  return results[0] ?? null;
}

export async function getAllInstructors() {
  return db
    .select({
      id: instructor.id,
      userId: instructor.userId,
      title: instructor.title,
      firstName: instructor.firstName,
      lastName: instructor.lastName,
      email: instructor.email,
      phone: instructor.phone,
      position: instructor.position,
    })
    .from(instructor);
}

export async function getInstructorById(id: number) {
  const results = await db
    .select({
      id: instructor.id,
      userId: instructor.userId,
      title: instructor.title,
      firstName: instructor.firstName,
      lastName: instructor.lastName,
      email: instructor.email,
      phone: instructor.phone,
      position: instructor.position,
      profile: instructor.profile,
    })
    .from(instructor)
    .where(eq(instructor.id, id))
    .limit(1);

  return results[0] ?? null;
}
