import { requireRole } from "@/lib/auth-utils";
import {
  getFinancialReport,
  getClassPopularityReport,
  getAttendanceReport,
} from "@/lib/db/queries/report-queries";
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export default async function ReportsPage() {
  await requireRole(["manager"]);

  const now = new Date();
  const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
  const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);

  const [financial, popularity, attendance] = await Promise.all([
    getFinancialReport(startDate, endDate),
    getClassPopularityReport(startDate, endDate),
    getAttendanceReport(startDate, endDate),
  ]);

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Reports</h1>

      <Tabs defaultValue={0}>
        <TabsList>
          <TabsTrigger value={0}>Financial</TabsTrigger>
          <TabsTrigger value={1}>Class Popularity</TabsTrigger>
          <TabsTrigger value={2}>Attendance</TabsTrigger>
        </TabsList>

        <TabsContent value={0}>
          <Card>
            <CardHeader>
              <CardTitle>Financial Report - Current Month</CardTitle>
            </CardHeader>
            <CardContent>
              {financial.length === 0 ? (
                <p className="text-muted-foreground">No financial data found.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Product</TableHead>
                      <TableHead>Total Amount</TableHead>
                      <TableHead>Payment Count</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {financial.map((row) => (
                      <TableRow key={row.productName}>
                        <TableCell className="font-medium">{row.productName}</TableCell>
                        <TableCell>${Number(row.totalAmount).toFixed(2)}</TableCell>
                        <TableCell>{row.paymentCount}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value={1}>
          <Card>
            <CardHeader>
              <CardTitle>Class Popularity Report - Current Month</CardTitle>
            </CardHeader>
            <CardContent>
              {popularity.length === 0 ? (
                <p className="text-muted-foreground">No class data found.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Class Name</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Total Bookings</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {popularity.map((row) => (
                      <TableRow key={row.className}>
                        <TableCell className="font-medium">{row.className}</TableCell>
                        <TableCell>{row.classTypeName}</TableCell>
                        <TableCell>{row.totalBookings}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value={2}>
          <Card>
            <CardHeader>
              <CardTitle>Attendance Report - Current Month</CardTitle>
            </CardHeader>
            <CardContent>
              {attendance.length === 0 ? (
                <p className="text-muted-foreground">No attendance data found.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Class Name</TableHead>
                      <TableHead>Total Booked</TableHead>
                      <TableHead>Total Attended</TableHead>
                      <TableHead>Rate</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {attendance.map((row) => {
                      const rate =
                        row.totalBooked > 0
                          ? ((Number(row.totalAttended) / Number(row.totalBooked)) * 100).toFixed(1)
                          : "0.0";
                      return (
                        <TableRow key={row.className}>
                          <TableCell className="font-medium">{row.className}</TableCell>
                          <TableCell>{row.totalBooked}</TableCell>
                          <TableCell>{row.totalAttended}</TableCell>
                          <TableCell>{rate}%</TableCell>
                        </TableRow>
                      );
                    })}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
