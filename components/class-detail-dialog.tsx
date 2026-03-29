"use client";

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { bookClass, cancelBooking } from "@/lib/actions/booking-actions";
import { toast } from "sonner";
import { formatDateTime } from "@/lib/utils";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface ClassDetailDialogProps {
  event: CalendarEvent | null;
  open: boolean;
  onClose: () => void;
  isBooked?: boolean;
  bookingId?: number;
  isMember: boolean;
}

export function ClassDetailDialog({
  event,
  open,
  onClose,
  isBooked,
  bookingId,
  isMember,
}: ClassDetailDialogProps) {
  const [loading, setLoading] = useState(false);

  if (!event) return null;
  const props = event.extendedProps;

  async function handleBook() {
    setLoading(true);
    const result = await bookClass(props.classId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Class booked successfully!");
      onClose();
    }
    setLoading(false);
  }

  async function handleCancel() {
    if (!bookingId) return;
    setLoading(true);
    const result = await cancelBooking(bookingId, props.classId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Booking cancelled");
      onClose();
    }
    setLoading(false);
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{event.title}</DialogTitle>
        </DialogHeader>
        <div className="space-y-3 text-sm">
          <div className="flex justify-between">
            <span className="text-muted-foreground">Type</span>
            <Badge variant="outline">{props.classType}</Badge>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Time</span>
            <span>{formatDateTime(event.start)} - {formatDateTime(event.end)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Instructor</span>
            <span>{props.instructorName}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Location</span>
            <span>{props.locationName}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Available Slots</span>
            <span>{props.openSlots}</span>
          </div>
        </div>
        {isMember && (
          <div className="mt-4">
            {isBooked ? (
              <Button
                variant="destructive"
                className="w-full"
                onClick={handleCancel}
                disabled={loading}
              >
                {loading ? "Cancelling..." : "Cancel Booking"}
              </Button>
            ) : props.openSlots > 0 ? (
              <Button
                className="w-full"
                onClick={handleBook}
                disabled={loading}
              >
                {loading ? "Booking..." : "Book This Class"}
              </Button>
            ) : (
              <Button className="w-full" disabled>
                Class Full
              </Button>
            )}
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
