import Link from "next/link";
import { Button } from "@/components/ui/button";

export function PublicNavbar() {
  return (
    <nav className="border-b bg-card">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <Link href="/" className="text-xl font-bold text-primary">Countryside Swimming Club</Link>
        <div className="flex items-center gap-6">
          <Link href="/timetable" className="text-sm text-muted-foreground hover:text-foreground">Timetable</Link>
          <Link href="/courses" className="text-sm text-muted-foreground hover:text-foreground">Courses</Link>
          <Link href="/instructors" className="text-sm text-muted-foreground hover:text-foreground">Instructors</Link>
          <Link href="/news" className="text-sm text-muted-foreground hover:text-foreground">News</Link>
          <Button asChild size="sm"><Link href="/login">Sign In</Link></Button>
        </div>
      </div>
    </nav>
  );
}
