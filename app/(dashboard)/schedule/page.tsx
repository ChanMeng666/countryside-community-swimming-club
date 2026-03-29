import { requireSession } from "@/lib/auth-utils";
import { getClassesForCalendar } from "@/lib/db/queries/class-queries";
import {
  getMemberIdByUserId,
  getMemberBookings,
} from "@/lib/db/queries/booking-queries";
import { TimetableClient } from "./timetable-client";

export default async function DashboardTimetablePage() {
  const session = await requireSession();
  const role = session.user.role as string;

  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0);
  const events = await getClassesForCalendar(start, end);

  let memberBookings: { classId: number; bookingId: number }[] = [];
  if (role === "member") {
    const memberId = await getMemberIdByUserId(session.user.id);
    if (memberId) {
      const bookings = await getMemberBookings(memberId);
      memberBookings = bookings.map((b) => ({
        classId: b.classId,
        bookingId: b.bookingId,
      }));
    }
  }

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Timetable</h1>
      <TimetableClient
        events={events}
        isMember={role === "member"}
        memberBookings={memberBookings}
      />
    </div>
  );
}
