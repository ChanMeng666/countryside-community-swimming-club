import { requireRole } from "@/lib/auth-utils";
import {
  getMemberIdByUserId,
  getMemberBookings,
} from "@/lib/db/queries/booking-queries";
import { cancelBooking } from "@/lib/actions/booking-actions";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { formatDate, formatTime } from "@/lib/utils";
import { CancelBookingButton } from "./cancel-button";

export default async function BookingPage() {
  const session = await requireRole(["member"]);
  const memberId = await getMemberIdByUserId(session.user.id);

  if (!memberId) {
    return (
      <div>
        <h1 className="text-2xl font-bold mb-4">My Bookings</h1>
        <p className="text-muted-foreground">
          No member profile found. Please contact a manager.
        </p>
      </div>
    );
  }

  const bookings = await getMemberBookings(memberId);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">My Bookings</h1>
      {bookings.length === 0 ? (
        <p className="text-muted-foreground">
          No upcoming bookings. Visit the timetable to book a class.
        </p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Class</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Time</TableHead>
              <TableHead>Instructor</TableHead>
              <TableHead>Location</TableHead>
              <TableHead>Type</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {bookings.map((b) => (
              <TableRow key={b.bookingId}>
                <TableCell className="font-medium">{b.className}</TableCell>
                <TableCell>{formatDate(b.startTime)}</TableCell>
                <TableCell>
                  {formatTime(b.startTime)} - {formatTime(b.endTime)}
                </TableCell>
                <TableCell>
                  {b.instructorFirstName} {b.instructorLastName}
                </TableCell>
                <TableCell>
                  {b.poolName} {b.laneName}
                </TableCell>
                <TableCell>
                  <Badge variant="outline">{b.classTypeName}</Badge>
                </TableCell>
                <TableCell>
                  <CancelBookingButton
                    bookingId={b.bookingId}
                    classId={b.classId}
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
