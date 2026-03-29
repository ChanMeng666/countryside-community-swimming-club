import { db } from "@/lib/db";
import { classType } from "@/lib/db/schema";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default async function CoursesPage() {
  const courses = await db.select().from(classType);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-2">Our Courses</h1>
      <p className="text-muted-foreground mb-6">
        Browse the swimming courses we offer at our club.
      </p>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {courses.map((course) => (
          <Card key={course.id}>
            <CardHeader>
              <CardTitle>{course.className}</CardTitle>
              <Badge variant="outline">{course.type}</Badge>
            </CardHeader>
            <CardContent>
              <CardDescription>
                {course.description ?? "No description available."}
              </CardDescription>
            </CardContent>
          </Card>
        ))}
      </div>
      {courses.length === 0 && (
        <p className="text-center text-muted-foreground mt-8">
          No courses available at the moment.
        </p>
      )}
    </div>
  );
}
