import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Calendar, Users, Award } from "lucide-react";

export default function HomePage() {
  return (
    <div>
      <section className="bg-primary/5 py-20">
        <div className="container mx-auto px-4 text-center">
          <h1 className="text-4xl font-bold tracking-tight md:text-5xl">
            Countryside Community<br /><span className="text-primary">Swimming Club</span>
          </h1>
          <p className="mt-4 text-lg text-muted-foreground max-w-2xl mx-auto">
            Join our community and enjoy swimming lessons, group sessions, and private coaching for all skill levels.
          </p>
          <div className="mt-8 flex gap-4 justify-center">
            <Button asChild size="lg"><Link href="/register">Join Now</Link></Button>
            <Button asChild variant="outline" size="lg"><Link href="/timetable">View Timetable</Link></Button>
          </div>
        </div>
      </section>
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-3 gap-8">
            <Card>
              <CardContent className="pt-6 text-center">
                <Calendar className="h-10 w-10 mx-auto text-primary mb-4" />
                <h3 className="font-semibold text-lg mb-2">Flexible Schedule</h3>
                <p className="text-sm text-muted-foreground">Book classes that fit your timetable. Morning, afternoon, and evening sessions available.</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6 text-center">
                <Users className="h-10 w-10 mx-auto text-primary mb-4" />
                <h3 className="font-semibold text-lg mb-2">Expert Instructors</h3>
                <p className="text-sm text-muted-foreground">Learn from certified swimming instructors with years of experience.</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6 text-center">
                <Award className="h-10 w-10 mx-auto text-primary mb-4" />
                <h3 className="font-semibold text-lg mb-2">All Levels</h3>
                <p className="text-sm text-muted-foreground">From beginners to advanced swimmers. Group classes, 1-on-1 lessons, and training sessions.</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>
    </div>
  );
}
