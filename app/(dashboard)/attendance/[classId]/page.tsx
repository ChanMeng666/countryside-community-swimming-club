import { requireRole } from "@/lib/auth-utils";
import { getClassAttendance } from "@/lib/db/queries/booking-queries";
import { AttendanceForm } from "./attendance-form";

export default async function AttendanceClassPage({
  params,
}: {
  params: Promise<{ classId: string }>;
}) {
  await requireRole(["instructor", "manager"]);
  const { classId } = await params;
  const attendance = await getClassAttendance(Number(classId));

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Mark Attendance</h1>
      <AttendanceForm classId={Number(classId)} attendance={attendance} />
    </div>
  );
}
