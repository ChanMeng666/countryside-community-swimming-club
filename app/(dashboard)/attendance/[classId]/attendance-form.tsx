"use client";

import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { markAttendance } from "@/lib/actions/booking-actions";
import { toast } from "sonner";
import { Check, X } from "lucide-react";

interface AttendanceFormProps {
  classId: number;
  attendance: {
    bookingId: number;
    memberId: number;
    isAttended: boolean;
    firstName: string;
    lastName: string;
    email: string;
  }[];
}

export function AttendanceForm({ classId, attendance }: AttendanceFormProps) {
  const [states, setStates] = useState(
    attendance.reduce(
      (acc, a) => ({ ...acc, [a.memberId]: a.isAttended }),
      {} as Record<number, boolean>
    )
  );

  async function toggle(memberId: number) {
    const newState = !states[memberId];
    setStates((s) => ({ ...s, [memberId]: newState }));
    const result = await markAttendance(memberId, classId, newState);
    if (result.success) {
      toast.success("Attendance updated");
    }
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Member</TableHead>
          <TableHead>Email</TableHead>
          <TableHead>Attended</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {attendance.map((a) => (
          <TableRow key={a.memberId}>
            <TableCell>
              {a.firstName} {a.lastName}
            </TableCell>
            <TableCell>{a.email}</TableCell>
            <TableCell>
              <Button
                variant={states[a.memberId] ? "default" : "outline"}
                size="sm"
                onClick={() => toggle(a.memberId)}
              >
                {states[a.memberId] ? (
                  <Check className="h-4 w-4" />
                ) : (
                  <X className="h-4 w-4" />
                )}
              </Button>
            </TableCell>
          </TableRow>
        ))}
        {attendance.length === 0 && (
          <TableRow>
            <TableCell colSpan={3} className="text-center text-muted-foreground">
              No bookings for this class.
            </TableCell>
          </TableRow>
        )}
      </TableBody>
    </Table>
  );
}
