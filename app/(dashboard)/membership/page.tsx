import { requireRole } from "@/lib/auth-utils";
import { getMemberIdByUserId } from "@/lib/db/queries/booking-queries";
import {
  getMemberProfile,
  getAllProducts,
  getMemberPayments,
} from "@/lib/db/queries/membership-queries";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatDate } from "@/lib/utils";
import { MembershipActions } from "./membership-actions-client";

export default async function MembershipPage() {
  const session = await requireRole(["member"]);
  const memberId = await getMemberIdByUserId(session.user.id);

  if (!memberId) {
    return (
      <div>
        <h1 className="text-2xl font-bold mb-4">Membership</h1>
        <p className="text-muted-foreground">
          No member profile found. Please contact a manager.
        </p>
      </div>
    );
  }

  const [profile, products, payments] = await Promise.all([
    getMemberProfile(memberId),
    getAllProducts(),
    getMemberPayments(memberId),
  ]);

  const isActive =
    profile.expiredDate && new Date(profile.expiredDate) > new Date();

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Membership</h1>

      <Card>
        <CardHeader>
          <CardTitle>Membership Status</CardTitle>
          <CardDescription>Your current membership details</CardDescription>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex items-center gap-2">
            <span className="font-medium">Status:</span>
            <Badge variant={isActive ? "default" : "secondary"}>
              {isActive ? "Active" : "Inactive"}
            </Badge>
          </div>
          <div>
            <span className="font-medium">Plan:</span>{" "}
            {profile.membershipType || "None"}
          </div>
          <div>
            <span className="font-medium">Expires:</span>{" "}
            {profile.expiredDate ? formatDate(profile.expiredDate) : "N/A"}
          </div>
        </CardContent>
      </Card>

      <MembershipActions
        products={products}
        isSubscribed={profile.isSubscription}
      />

      <Card>
        <CardHeader>
          <CardTitle>Payment History</CardTitle>
        </CardHeader>
        <CardContent>
          {payments.length === 0 ? (
            <p className="text-muted-foreground">No payments found.</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {payments.map((p) => (
                  <TableRow key={p.paymentId}>
                    <TableCell className="font-medium">
                      {p.productName}
                    </TableCell>
                    <TableCell>${p.total}</TableCell>
                    <TableCell>
                      <Badge variant={p.isPaid ? "default" : "secondary"}>
                        {p.isPaid ? "Paid" : "Pending"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {p.paidAt ? formatDate(p.paidAt) : "N/A"}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
