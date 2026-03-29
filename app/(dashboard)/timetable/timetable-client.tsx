"use client";

import { useState } from "react";
import { SwimmingCalendar } from "@/components/calendar";
import { ClassDetailDialog } from "@/components/class-detail-dialog";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface TimetableClientProps {
  events: CalendarEvent[];
  isMember: boolean;
  memberBookings: { classId: number; bookingId: number }[];
}

export function TimetableClient({
  events,
  isMember,
  memberBookings,
}: TimetableClientProps) {
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(
    null
  );

  function handleEventClick(classId: number) {
    const event = events.find((e) => e.extendedProps.classId === classId);
    if (event) setSelectedEvent(event);
  }

  const bookedClassId = selectedEvent?.extendedProps.classId;
  const bookingInfo = memberBookings.find((b) => b.classId === bookedClassId);

  return (
    <>
      <SwimmingCalendar
        events={events}
        onEventClick={handleEventClick}
        interactive
      />
      <ClassDetailDialog
        event={selectedEvent}
        open={!!selectedEvent}
        onClose={() => setSelectedEvent(null)}
        isMember={isMember}
        isBooked={!!bookingInfo}
        bookingId={bookingInfo?.bookingId}
      />
    </>
  );
}
