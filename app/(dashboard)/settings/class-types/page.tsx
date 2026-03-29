import { requireRole } from "@/lib/auth-utils";
import { db } from "@/lib/db";
import { classType } from "@/lib/db/schema";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { AddClassTypeDialog } from "./class-type-form";

export default async function ClassTypesSettingsPage() {
  await requireRole(["manager"]);

  const classTypes = await db.select().from(classType);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Class Types</h1>
        <AddClassTypeDialog />
      </div>

      {classTypes.length === 0 ? (
        <p className="text-muted-foreground">No class types found.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Description</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {classTypes.map((ct) => (
              <TableRow key={ct.id}>
                <TableCell className="font-medium">{ct.className}</TableCell>
                <TableCell>
                  <Badge variant="secondary">{ct.type}</Badge>
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {ct.description || "—"}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
