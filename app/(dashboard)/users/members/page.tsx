import { requireRole } from "@/lib/auth-utils";
import { getAllMembers } from "@/lib/db/queries/user-queries";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import Link from "next/link";

export default async function MembersPage() {
  await requireRole(["manager"]);
  const members = await getAllMembers();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Members</h1>
      {members.length === 0 ? (
        <p className="text-muted-foreground">No members found.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Membership</TableHead>
              <TableHead>Status</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {members.map((m) => (
              <TableRow key={m.id}>
                <TableCell className="font-medium">
                  {m.firstName} {m.lastName}
                </TableCell>
                <TableCell>{m.email}</TableCell>
                <TableCell>{m.phone}</TableCell>
                <TableCell>{m.membershipType ?? "None"}</TableCell>
                <TableCell>
                  <Badge variant={m.isActive ? "default" : "secondary"}>
                    {m.isActive ? "Active" : "Inactive"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Link href={`/users/members/${m.id}`} className={buttonVariants({ size: "sm", variant: "outline" })}>View</Link>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
