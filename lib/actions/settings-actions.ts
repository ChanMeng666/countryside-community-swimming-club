"use server";

import { db } from "@/lib/db";
import { classType, location, product } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";

// Class Type actions
export async function createClassType(data: {
  type: "class" | "1-on-1" | "group";
  className: string;
  description?: string;
}) {
  await requireRole(["manager"]);

  await db.insert(classType).values({
    type: data.type,
    className: data.className,
    description: data.description || null,
  });

  revalidatePath("/settings/class-types");
  return { success: true };
}

export async function updateClassType(
  id: number,
  data: {
    type?: "class" | "1-on-1" | "group";
    className?: string;
    description?: string;
  }
) {
  await requireRole(["manager"]);

  await db
    .update(classType)
    .set({
      ...(data.type && { type: data.type }),
      ...(data.className && { className: data.className }),
      ...(data.description !== undefined && { description: data.description }),
    })
    .where(eq(classType.id, id));

  revalidatePath("/settings/class-types");
  return { success: true };
}

// Location actions
export async function createLocation(data: {
  poolName: string;
  laneName: string;
}) {
  await requireRole(["manager"]);

  await db.insert(location).values({
    poolName: data.poolName,
    laneName: data.laneName,
    status: "available",
  });

  revalidatePath("/settings/locations");
  return { success: true };
}

export async function updateLocationStatus(
  id: number,
  status: "available" | "unavailable"
) {
  await requireRole(["manager"]);

  await db
    .update(location)
    .set({ status })
    .where(eq(location.id, id));

  revalidatePath("/settings/locations");
  return { success: true };
}

// Product actions
export async function createProduct(data: {
  name: string;
  description?: string;
  price: string;
}) {
  await requireRole(["manager"]);

  await db.insert(product).values({
    name: data.name,
    description: data.description || null,
    price: data.price,
  });

  revalidatePath("/settings/pricing");
  return { success: true };
}

export async function updateProduct(
  id: number,
  data: {
    name?: string;
    description?: string;
    price?: string;
  }
) {
  await requireRole(["manager"]);

  await db
    .update(product)
    .set({
      ...(data.name && { name: data.name }),
      ...(data.description !== undefined && { description: data.description }),
      ...(data.price && { price: data.price }),
    })
    .where(eq(product.id, id));

  revalidatePath("/settings/pricing");
  return { success: true };
}
