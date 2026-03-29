import { getNewsById } from "@/lib/actions/news-actions";
import { formatDate } from "@/lib/utils";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default async function NewsDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const article = await getNewsById(Number(id));

  if (!article) notFound();

  return (
    <div className="container mx-auto px-4 py-8 max-w-3xl">
      <Link href="/news">
        <Button variant="ghost" className="mb-4">
          &larr; Back to News
        </Button>
      </Link>

      <h1 className="text-3xl font-bold mb-2">{article.title}</h1>
      <p className="text-muted-foreground mb-6">
        By {article.authorName} &middot;{" "}
        {article.createdAt ? formatDate(article.createdAt) : ""}
      </p>

      <div className="prose prose-neutral dark:prose-invert max-w-none whitespace-pre-wrap">
        {article.content}
      </div>
    </div>
  );
}
