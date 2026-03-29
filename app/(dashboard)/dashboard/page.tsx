import { requireSession } from "@/lib/auth-utils";

export default async function DashboardPage() {
  const session = await requireSession();
  const role = session.user.role as string;

  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      <p className="text-muted-foreground">
        Welcome back, {session.user.name}. You are logged in as{" "}
        <span className="font-medium capitalize">{role}</span>.
      </p>
    </div>
  );
}
