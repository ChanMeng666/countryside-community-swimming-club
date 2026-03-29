import { requireRole } from "@/lib/auth-utils";
import { getClassesForCalendar } from "@/lib/db/queries/class-queries";
import { getFormData } from "@/lib/actions/class-actions";
import { ManageTimetableClient } from "./manage-client";

export default async function ManageTimetablePage() {
  await requireRole(["manager"]);

  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0);

  const [events, formData] = await Promise.all([
    getClassesForCalendar(start, end),
    getFormData(),
  ]);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Manage Timetable</h1>
      <ManageTimetableClient events={events} formData={formData} />
    </div>
  );
}
