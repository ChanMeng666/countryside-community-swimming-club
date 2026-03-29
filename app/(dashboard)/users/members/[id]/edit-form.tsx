"use client";

import { updateMember } from "@/lib/actions/user-actions";
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

interface MemberData {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  address: string | null;
  dob: string | null;
  healthInfo: string | null;
}

interface MemberEditFormProps {
  member: MemberData;
}

export function MemberEditForm({ member }: MemberEditFormProps) {
  const [isPending, startTransition] = useTransition();

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);

    startTransition(async () => {
      const result = await updateMember(member.id, {
        firstName: formData.get("firstName") as string,
        lastName: formData.get("lastName") as string,
        email: formData.get("email") as string,
        phone: formData.get("phone") as string,
        address: (formData.get("address") as string) || undefined,
        dob: (formData.get("dob") as string) || undefined,
        healthInfo: (formData.get("healthInfo") as string) || undefined,
      });

      if ("error" in result) {
        toast.error("Failed to update member.");
      } else {
        toast.success("Member updated successfully!");
      }
    });
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Member Details</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="firstName">First Name</Label>
              <Input
                id="firstName"
                name="firstName"
                defaultValue={member.firstName}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="lastName">Last Name</Label>
              <Input
                id="lastName"
                name="lastName"
                defaultValue={member.lastName}
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                name="email"
                type="email"
                defaultValue={member.email}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="phone">Phone</Label>
              <Input
                id="phone"
                name="phone"
                defaultValue={member.phone}
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="address">Address</Label>
            <Input
              id="address"
              name="address"
              defaultValue={member.address ?? ""}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="dob">Date of Birth</Label>
            <Input
              id="dob"
              name="dob"
              type="date"
              defaultValue={member.dob ?? ""}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="healthInfo">Health Information</Label>
            <Textarea
              id="healthInfo"
              name="healthInfo"
              defaultValue={member.healthInfo ?? ""}
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
