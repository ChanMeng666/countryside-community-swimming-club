import { requireRole } from "@/lib/auth-utils";
import { getAllInstructors } from "@/lib/db/queries/user-queries";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { LinkButton } from "@/components/link-button";
import Link from "next/link";

export default async function InstructorsPage() {
  await requireRole(["manager"]);
  const instructors = await getAllInstructors();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Instructors</h1>
      {instructors.length === 0 ? (
        <p className="text-muted-foreground">No instructors found.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Position</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {instructors.map((i) => (
              <TableRow key={i.id}>
                <TableCell className="font-medium">
                  {i.title} {i.firstName} {i.lastName}
                </TableCell>
                <TableCell>{i.email}</TableCell>
                <TableCell>{i.phone}</TableCell>
                <TableCell>{i.position}</TableCell>
                <TableCell>
                  <LinkButton href={`/users/instructors/${i.id}`} size="sm" variant="outline">View</LinkButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
