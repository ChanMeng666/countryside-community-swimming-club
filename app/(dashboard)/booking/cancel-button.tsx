"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { cancelBooking } from "@/lib/actions/booking-actions";
import { toast } from "sonner";

export function CancelBookingButton({
  bookingId,
  classId,
}: {
  bookingId: number;
  classId: number;
}) {
  const [loading, setLoading] = useState(false);

  async function handleCancel() {
    setLoading(true);
    const result = await cancelBooking(bookingId, classId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Booking cancelled");
    }
    setLoading(false);
  }

  return (
    <Button
      variant="destructive"
      size="sm"
      onClick={handleCancel}
      disabled={loading}
    >
      {loading ? "..." : "Cancel"}
    </Button>
  );
}
