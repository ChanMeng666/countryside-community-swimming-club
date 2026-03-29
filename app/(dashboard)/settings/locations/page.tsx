import { requireRole } from "@/lib/auth-utils";
import { db } from "@/lib/db";
import { location } from "@/lib/db/schema";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  AddLocationDialog,
  ToggleStatusButton,
  LocationStatusBadge,
} from "./location-form";

export default async function LocationsSettingsPage() {
  await requireRole(["manager"]);

  const locations = await db.select().from(location);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Locations</h1>
        <AddLocationDialog />
      </div>

      {locations.length === 0 ? (
        <p className="text-muted-foreground">No locations found.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Pool Name</TableHead>
              <TableHead>Lane Name</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {locations.map((loc) => (
              <TableRow key={loc.id}>
                <TableCell className="font-medium">
                  {loc.poolName || "—"}
                </TableCell>
                <TableCell>{loc.laneName || "—"}</TableCell>
                <TableCell>
                  <LocationStatusBadge
                    status={loc.status as "available" | "unavailable"}
                  />
                </TableCell>
                <TableCell>
                  <ToggleStatusButton
                    id={loc.id}
                    currentStatus={loc.status as "available" | "unavailable"}
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
