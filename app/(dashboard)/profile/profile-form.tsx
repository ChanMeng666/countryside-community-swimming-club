"use client";

import { updateProfile } from "@/lib/actions/profile-actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import { useTransition } from "react";

interface ProfileFormProps {
  role: string;
  initialData: Record<string, string>;
}

export function ProfileForm({ role, initialData }: ProfileFormProps) {
  const [isPending, startTransition] = useTransition();

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const data: Record<string, string> = {};
    formData.forEach((value, key) => {
      data[key] = value as string;
    });

    startTransition(async () => {
      const result = await updateProfile(data);
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Profile updated successfully!");
      }
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {(role === "instructor" || role === "manager") && (
        <div className="space-y-2">
          <Label htmlFor="title">Title</Label>
          <Input
            id="title"
            name="title"
            defaultValue={initialData.title || ""}
            required
          />
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="firstName">First Name</Label>
          <Input
            id="firstName"
            name="firstName"
            defaultValue={initialData.firstName || ""}
            required
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="lastName">Last Name</Label>
          <Input
            id="lastName"
            name="lastName"
            defaultValue={initialData.lastName || ""}
            required
          />
        </div>
      </div>

      {(role === "instructor" || role === "manager") && (
        <div className="space-y-2">
          <Label htmlFor="position">Position</Label>
          <Input
            id="position"
            name="position"
            defaultValue={initialData.position || ""}
            required
          />
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="email">Email</Label>
          <Input
            id="email"
            name="email"
            type="email"
            defaultValue={initialData.email || ""}
            required
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="phone">Phone</Label>
          <Input
            id="phone"
            name="phone"
            defaultValue={initialData.phone || ""}
            required
          />
        </div>
      </div>

      {role === "member" && (
        <>
          <div className="space-y-2">
            <Label htmlFor="address">Address</Label>
            <Input
              id="address"
              name="address"
              defaultValue={initialData.address || ""}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="dob">Date of Birth</Label>
            <Input
              id="dob"
              name="dob"
              type="date"
              defaultValue={initialData.dob || ""}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="healthInfo">Health Information</Label>
            <Textarea
              id="healthInfo"
              name="healthInfo"
              defaultValue={initialData.healthInfo || ""}
              rows={3}
            />
          </div>
        </>
      )}

      {role === "instructor" && (
        <div className="space-y-2">
          <Label htmlFor="profile">Profile</Label>
          <Textarea
            id="profile"
            name="profile"
            defaultValue={initialData.profile || ""}
            rows={4}
          />
        </div>
      )}

      <Button type="submit" disabled={isPending}>
        {isPending ? "Saving..." : "Save Changes"}
      </Button>
    </form>
  );
}
