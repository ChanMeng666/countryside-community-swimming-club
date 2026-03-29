import { requireRole } from "@/lib/auth-utils";
import { getAllNews } from "@/lib/actions/news-actions";
import { NewsManageClient } from "./news-manage-client";

export default async function NewsManagePage() {
  await requireRole(["manager"]);
  const articles = await getAllNews();

  return <NewsManageClient articles={articles} />;
}
