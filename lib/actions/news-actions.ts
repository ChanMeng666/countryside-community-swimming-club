"use server";

import { dbPool } from "@/lib/db/transaction";
import { news, manager } from "@/lib/db/schema";
import { eq, desc } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";

export async function getAllNews() {
  const rows = await dbPool
    .select({
      id: news.id,
      title: news.title,
      content: news.content,
      createdAt: news.createdAt,
      authorFirstName: manager.firstName,
      authorLastName: manager.lastName,
    })
    .from(news)
    .innerJoin(manager, eq(news.authorId, manager.id))
    .orderBy(desc(news.createdAt));

  return rows.map((r) => ({
    ...r,
    authorName: `${r.authorFirstName} ${r.authorLastName}`,
  }));
}

export async function getNewsById(id: number) {
  const [row] = await dbPool
    .select({
      id: news.id,
      title: news.title,
      content: news.content,
      createdAt: news.createdAt,
      authorFirstName: manager.firstName,
      authorLastName: manager.lastName,
    })
    .from(news)
    .innerJoin(manager, eq(news.authorId, manager.id))
    .where(eq(news.id, id));

  if (!row) return null;

  return {
    ...row,
    authorName: `${row.authorFirstName} ${row.authorLastName}`,
  };
}

export async function createNews(data: { title: string; content: string }) {
  const session = await requireRole(["manager"]);

  const [mgr] = await dbPool
    .select({ id: manager.id })
    .from(manager)
    .where(eq(manager.userId, session.user.id));

  if (!mgr) return { error: "Manager profile not found" };

  try {
    await dbPool.insert(news).values({
      authorId: mgr.id,
      title: data.title,
      content: data.content,
    });

    revalidatePath("/news");
    revalidatePath("/news/manage");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Failed to create news" };
  }
}

export async function deleteNews(id: number) {
  await requireRole(["manager"]);

  try {
    await dbPool.delete(news).where(eq(news.id, id));

    revalidatePath("/news");
    revalidatePath("/news/manage");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Failed to delete news" };
  }
}
