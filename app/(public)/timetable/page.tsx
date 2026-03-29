import { getClassesForCalendar } from "@/lib/db/queries/class-queries";
import { SwimmingCalendar } from "@/components/calendar";

export default async function PublicTimetablePage() {
  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0);
  const events = await getClassesForCalendar(start, end);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Class Timetable</h1>
      <p className="text-muted-foreground mb-6">Browse our upcoming swimming classes. Sign in to book a spot.</p>
      <SwimmingCalendar events={events} />
    </div>
  );
}
