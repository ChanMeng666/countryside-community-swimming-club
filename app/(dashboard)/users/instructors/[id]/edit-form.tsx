"use client";

import { updateInstructor } from "@/lib/actions/user-actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { toast } from "sonner";
import { useTransition } from "react";

interface InstructorData {
  id: number;
  title: string;
  firstName: string;
  lastName: string;
  position: string;
  phone: string;
  email: string;
  profile: string | null;
}

interface InstructorEditFormProps {
  instructor: InstructorData;
}

export function InstructorEditForm({ instructor }: InstructorEditFormProps) {
  const [isPending, startTransition] = useTransition();

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);

    startTransition(async () => {
      const result = await updateInstructor(instructor.id, {
        title: formData.get("title") as string,
        firstName: formData.get("firstName") as string,
        lastName: formData.get("lastName") as string,
        position: formData.get("position") as string,
        phone: formData.get("phone") as string,
        email: formData.get("email") as string,
        profile: (formData.get("profile") as string) || undefined,
      });

      if ("error" in result) {
        toast.error("Failed to update instructor.");
      } else {
        toast.success("Instructor updated successfully!");
      }
    });
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Instructor Details</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                name="title"
                defaultValue={instructor.title}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="firstName">First Name</Label>
              <Input
                id="firstName"
                name="firstName"
                defaultValue={instructor.firstName}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="lastName">Last Name</Label>
              <Input
                id="lastName"
                name="lastName"
                defaultValue={instructor.lastName}
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="position">Position</Label>
            <Input
              id="position"
              name="position"
              defaultValue={instructor.position}
              required
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="phone">Phone</Label>
              <Input
                id="phone"
                name="phone"
                defaultValue={instructor.phone}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                name="email"
                type="email"
                defaultValue={instructor.email}
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="profile">Profile</Label>
            <Textarea
              id="profile"
              name="profile"
              defaultValue={instructor.profile ?? ""}
              rows={4}
            />
          </div>

          <Button type="submit" disabled={isPending}>
            {isPending ? "Saving..." : "Save Changes"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
