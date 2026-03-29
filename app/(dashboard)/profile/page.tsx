import { requireSession } from "@/lib/auth-utils";
import { db } from "@/lib/db";
import { member, instructor, manager } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ProfileForm } from "./profile-form";

export default async function ProfilePage() {
  const session = await requireSession();
  const role = session.user.role as string;
  const userId = session.user.id;

  let profileData: Record<string, string> = {};

  if (role === "member") {
    const [row] = await db
      .select()
      .from(member)
      .where(eq(member.userId, userId))
      .limit(1);

    if (!row) {
      return (
        <div>
          <h1 className="text-2xl font-bold mb-4">Profile</h1>
          <p className="text-muted-foreground">
            No member profile found. Please contact a manager.
          </p>
        </div>
      );
    }

    profileData = {
      firstName: row.firstName,
      lastName: row.lastName,
      phone: row.phone,
      email: row.email,
      address: row.address || "",
      dob: row.dob || "",
      healthInfo: row.healthInfo || "",
    };
  } else if (role === "instructor") {
    const [row] = await db
      .select()
      .from(instructor)
      .where(eq(instructor.userId, userId))
      .limit(1);

    if (!row) {
      return (
        <div>
          <h1 className="text-2xl font-bold mb-4">Profile</h1>
          <p className="text-muted-foreground">
            No instructor profile found. Please contact a manager.
          </p>
        </div>
      );
    }

    profileData = {
      title: row.title,
      firstName: row.firstName,
      lastName: row.lastName,
      position: row.position,
      phone: row.phone,
      email: row.email,
      profile: row.profile || "",
    };
  } else if (role === "manager") {
    const [row] = await db
      .select()
      .from(manager)
      .where(eq(manager.userId, userId))
      .limit(1);

    if (!row) {
      return (
        <div>
          <h1 className="text-2xl font-bold mb-4">Profile</h1>
          <p className="text-muted-foreground">
            No manager profile found.
          </p>
        </div>
      );
    }

    profileData = {
      title: row.title,
      firstName: row.firstName,
      lastName: row.lastName,
      position: row.position,
      phone: row.phone,
      email: row.email,
    };
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Profile</h1>

      <Card>
        <CardHeader>
          <CardTitle>Edit Profile</CardTitle>
          <CardDescription>
            Update your personal information
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ProfileForm role={role} initialData={profileData} />
        </CardContent>
      </Card>
    </div>
  );
}
