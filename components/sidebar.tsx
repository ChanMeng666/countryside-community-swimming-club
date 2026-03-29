"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  Calendar, ClipboardList, CreditCard, Users, UserCog, Settings,
  BarChart3, Newspaper, User, LayoutDashboard, MapPin, Tag, DollarSign, CheckSquare,
} from "lucide-react";

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  roles: string[];
}

const navItems: NavItem[] = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard, roles: ["member", "instructor", "manager"] },
  { label: "Timetable", href: "/timetable", icon: Calendar, roles: ["member", "instructor", "manager"] },
  { label: "My Bookings", href: "/booking", icon: ClipboardList, roles: ["member"] },
  { label: "Membership", href: "/membership", icon: CreditCard, roles: ["member"] },
  { label: "Attendance", href: "/attendance", icon: CheckSquare, roles: ["instructor", "manager"] },
  { label: "Members", href: "/users/members", icon: Users, roles: ["manager"] },
  { label: "Instructors", href: "/users/instructors", icon: UserCog, roles: ["manager"] },
  { label: "Class Types", href: "/settings/class-types", icon: Tag, roles: ["manager"] },
  { label: "Locations", href: "/settings/locations", icon: MapPin, roles: ["manager"] },
  { label: "Pricing", href: "/settings/pricing", icon: DollarSign, roles: ["manager"] },
  { label: "Reports", href: "/reports", icon: BarChart3, roles: ["manager"] },
  { label: "News", href: "/news/manage", icon: Newspaper, roles: ["manager"] },
  { label: "Profile", href: "/profile", icon: User, roles: ["member", "instructor", "manager"] },
];

export function Sidebar({ userRole }: { userRole: string }) {
  const pathname = usePathname();
  const filteredItems = navItems.filter((item) => item.roles.includes(userRole));

  return (
    <aside className="hidden md:flex h-screen w-[220px] flex-col border-r bg-card">
      <div className="flex h-14 items-center border-b px-4">
        <Link href="/dashboard" className="flex items-center gap-2">
          <span className="text-lg font-bold text-primary">SCMS</span>
        </Link>
      </div>
      <nav className="flex-1 overflow-y-auto p-3 space-y-1">
        {filteredItems.map((item) => {
          const isActive = pathname === item.href || (item.href !== "/dashboard" && pathname.startsWith(item.href));
          return (
            <Link key={item.href} href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
                isActive ? "bg-primary/10 text-primary font-medium" : "text-muted-foreground hover:bg-muted hover:text-foreground"
              )}>
              <item.icon className="h-4 w-4" />
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
