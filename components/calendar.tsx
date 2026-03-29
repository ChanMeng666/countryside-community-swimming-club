"use client";

import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin from "@fullcalendar/interaction";
import type { EventClickArg } from "@fullcalendar/core";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface SwimmingCalendarProps {
  events: CalendarEvent[];
  onEventClick?: (classId: number) => void;
  interactive?: boolean;
}

export function SwimmingCalendar({ events, onEventClick, interactive = false }: SwimmingCalendarProps) {
  function handleEventClick(info: EventClickArg) {
    if (onEventClick) onEventClick(info.event.extendedProps.classId);
  }

  return (
    <FullCalendar
      plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin]}
      initialView="timeGridWeek"
      headerToolbar={{ left: "prev,next today", center: "title", right: "dayGridMonth,timeGridWeek,timeGridDay" }}
      events={events}
      eventClick={interactive ? handleEventClick : undefined}
      selectable={false}
      editable={false}
      slotMinTime="06:00:00"
      slotMaxTime="22:00:00"
      allDaySlot={false}
      height="auto"
      eventContent={(arg) => (
        <div className="p-1 text-xs">
          <div className="font-medium">{arg.event.title}</div>
          <div className="opacity-75">{arg.event.extendedProps.instructorName}</div>
          <div className="opacity-75">{arg.event.extendedProps.locationName} &middot; {arg.event.extendedProps.openSlots} slots</div>
        </div>
      )}
    />
  );
}
