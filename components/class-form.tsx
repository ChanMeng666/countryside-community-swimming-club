"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { createClass, updateClass } from "@/lib/actions/class-actions";
import { toast } from "sonner";

interface ClassFormProps {
  open: boolean;
  onClose: () => void;
  instructors: { id: number; firstName: string; lastName: string }[];
  locations: { id: number; poolName: string | null; laneName: string | null }[];
  classTypes: { id: number; className: string; type: string }[];
  editData?: {
    id: number;
    instructorId: number;
    locationId: number;
    classTypeId: number;
    startTime: string;
    endTime: string;
    openSlot: number;
  };
}

export function ClassForm({
  open,
  onClose,
  instructors,
  locations,
  classTypes,
  editData,
}: ClassFormProps) {
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const fd = new FormData(e.currentTarget);
    const data = {
      instructorId: Number(fd.get("instructorId")),
      locationId: Number(fd.get("locationId")),
      classTypeId: Number(fd.get("classTypeId")),
      startTime: fd.get("startTime") as string,
      endTime: fd.get("endTime") as string,
      openSlot: Number(fd.get("openSlot")),
    };

    const result = editData
      ? await updateClass(editData.id, data)
      : await createClass(data);

    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success(editData ? "Class updated" : "Class created");
      onClose();
    }
    setLoading(false);
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {editData ? "Edit Class" : "Add New Class"}
          </DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Instructor</Label>
            <Select
              name="instructorId"
              defaultValue={editData?.instructorId?.toString()}
              required
            >
              <SelectTrigger>
                <SelectValue placeholder="Select instructor" />
              </SelectTrigger>
              <SelectContent>
                {instructors.map((i) => (
                  <SelectItem key={i.id} value={String(i.id)}>
                    {i.firstName} {i.lastName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label>Location</Label>
            <Select
              name="locationId"
              defaultValue={editData?.locationId?.toString()}
              required
            >
              <SelectTrigger>
                <SelectValue placeholder="Select location" />
              </SelectTrigger>
              <SelectContent>
                {locations.map((l) => (
                  <SelectItem key={l.id} value={String(l.id)}>
                    {l.poolName} {l.laneName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label>Class Type</Label>
            <Select
              name="classTypeId"
              defaultValue={editData?.classTypeId?.toString()}
              required
            >
              <SelectTrigger>
                <SelectValue placeholder="Select class type" />
              </SelectTrigger>
              <SelectContent>
                {classTypes.map((ct) => (
                  <SelectItem key={ct.id} value={String(ct.id)}>
                    {ct.className} ({ct.type})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Start Time</Label>
              <Input
                name="startTime"
                type="datetime-local"
                defaultValue={editData?.startTime}
                required
              />
            </div>
            <div className="space-y-2">
              <Label>End Time</Label>
              <Input
                name="endTime"
                type="datetime-local"
                defaultValue={editData?.endTime}
                required
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label>Available Slots</Label>
            <Input
              name="openSlot"
              type="number"
              min={1}
              defaultValue={editData?.openSlot ?? 15}
              required
            />
          </div>
          <Button type="submit" className="w-full" disabled={loading}>
            {loading
              ? "Saving..."
              : editData
                ? "Update Class"
                : "Create Class"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
