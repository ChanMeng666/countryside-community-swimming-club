import { db } from "@/lib/db";
import { instructor } from "@/lib/db/schema";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";

export default async function InstructorsPage() {
  const instructors = await db.select().from(instructor);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-2">Our Instructors</h1>
      <p className="text-muted-foreground mb-6">
        Meet the qualified instructors at our swimming club.
      </p>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {instructors.map((inst) => (
          <Card key={inst.id}>
            <CardHeader className="flex flex-row items-center gap-4">
              <Avatar>
                <AvatarFallback>
                  {inst.firstName[0]}
                  {inst.lastName[0]}
                </AvatarFallback>
              </Avatar>
              <div>
                <CardTitle>
                  {inst.title} {inst.firstName} {inst.lastName}
                </CardTitle>
                <p className="text-sm text-muted-foreground">{inst.position}</p>
              </div>
            </CardHeader>
            <CardContent>
              <CardDescription>
                {inst.profile ?? "No profile available."}
              </CardDescription>
            </CardContent>
          </Card>
        ))}
      </div>
      {instructors.length === 0 && (
        <p className="text-center text-muted-foreground mt-8">
          No instructors available at the moment.
        </p>
      )}
    </div>
  );
}
