"use client";

import { createNews, deleteNews } from "@/lib/actions/news-actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { toast } from "sonner";
import { useTransition, useState } from "react";
import { formatDate } from "@/lib/utils";

interface NewsItem {
  id: number;
  title: string | null;
  content: string | null;
  createdAt: Date | null;
  authorName: string;
}

export function NewsManageClient({ articles }: { articles: NewsItem[] }) {
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");

  function handleCreate() {
    if (!title.trim() || !content.trim()) {
      toast.error("Title and content are required.");
      return;
    }
    startTransition(async () => {
      const result = await createNews({ title: title.trim(), content: content.trim() });
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("News article created.");
        setTitle("");
        setContent("");
        setOpen(false);
      }
    });
  }

  function handleDelete(id: number) {
    startTransition(async () => {
      const result = await deleteNews(id);
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("News article deleted.");
      }
    });
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Manage News</h1>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger render={<Button />}>
            Create News
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Create News Article</DialogTitle>
            </DialogHeader>
            <div className="space-y-4 pt-2">
              <div className="space-y-2">
                <Label htmlFor="title">Title</Label>
                <Input
                  id="title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Article title"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="content">Content</Label>
                <Textarea
                  id="content"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  placeholder="Article content"
                  rows={6}
                />
              </div>
              <Button onClick={handleCreate} disabled={isPending} className="w-full">
                {isPending ? "Creating..." : "Create"}
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {articles.length === 0 ? (
        <p className="text-muted-foreground">No news articles yet.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Author</TableHead>
              <TableHead>Date</TableHead>
              <TableHead className="w-[100px]">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {articles.map((article) => (
              <TableRow key={article.id}>
                <TableCell className="font-medium">{article.title}</TableCell>
                <TableCell>{article.authorName}</TableCell>
                <TableCell>
                  {article.createdAt ? formatDate(article.createdAt) : ""}
                </TableCell>
                <TableCell>
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={() => handleDelete(article.id)}
                    disabled={isPending}
                  >
                    Delete
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
