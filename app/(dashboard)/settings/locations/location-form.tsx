"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  createLocation,
  updateLocationStatus,
} from "@/lib/actions/settings-actions";
import { toast } from "sonner";
import { Plus } from "lucide-react";

export function AddLocationDialog() {
  const [open, setOpen] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [poolName, setPoolName] = useState("");
  const [laneName, setLaneName] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!poolName.trim() || !laneName.trim()) {
      toast.error("Pool name and lane name are required.");
      return;
    }

    startTransition(async () => {
      const result = await createLocation({
        poolName: poolName.trim(),
        laneName: laneName.trim(),
      });
      if (result.success) {
        toast.success("Location created successfully.");
        setOpen(false);
        setPoolName("");
        setLaneName("");
      }
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button />}>
        <Plus className="size-4 mr-2" />
        Add Location
      </DialogTrigger>
      <DialogContent>
        <form onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>Add Location</DialogTitle>
            <DialogDescription>
              Add a new pool lane location.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="poolName">Pool Name</Label>
              <Input
                id="poolName"
                value={poolName}
                onChange={(e) => setPoolName(e.target.value)}
                placeholder="e.g. Main Pool"
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="laneName">Lane Name</Label>
              <Input
                id="laneName"
                value={laneName}
                onChange={(e) => setLaneName(e.target.value)}
                placeholder="e.g. Lane 1"
                required
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={isPending}>
              {isPending ? "Creating..." : "Create"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}

export function ToggleStatusButton({
  id,
  currentStatus,
}: {
  id: number;
  currentStatus: "available" | "unavailable";
}) {
  const [isPending, startTransition] = useTransition();

  function handleToggle() {
    const newStatus =
      currentStatus === "available" ? "unavailable" : "available";
    startTransition(async () => {
      const result = await updateLocationStatus(id, newStatus);
      if (result.success) {
        toast.success(`Location marked as ${newStatus}.`);
      }
    });
  }

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={handleToggle}
      disabled={isPending}
    >
      {isPending
        ? "Updating..."
        : currentStatus === "available"
        ? "Set Unavailable"
        : "Set Available"}
    </Button>
  );
}

export function LocationStatusBadge({
  status,
}: {
  status: "available" | "unavailable";
}) {
  return (
    <Badge variant={status === "available" ? "default" : "destructive"}>
      {status}
    </Badge>
  );
}
