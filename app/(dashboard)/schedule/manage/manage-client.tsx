"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { SwimmingCalendar } from "@/components/calendar";
import { ClassForm } from "@/components/class-form";
import { Plus } from "lucide-react";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface ManageClientProps {
  events: CalendarEvent[];
  formData: {
    instructors: { id: number; firstName: string; lastName: string }[];
    locations: { id: number; poolName: string | null; laneName: string | null }[];
    classTypes: { id: number; className: string; type: string }[];
  };
}

export function ManageTimetableClient({
  events,
  formData,
}: ManageClientProps) {
  const [showForm, setShowForm] = useState(false);

  return (
    <>
      <div className="flex justify-end mb-4">
        <Button onClick={() => setShowForm(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Add Class
        </Button>
      </div>
      <SwimmingCalendar events={events} interactive />
      <ClassForm
        open={showForm}
        onClose={() => setShowForm(false)}
        {...formData}
      />
    </>
  );
}
