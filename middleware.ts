import { auth } from "@/lib/auth";
import { NextRequest, NextResponse } from "next/server";
import { headers } from "next/headers";

const protectedPaths = [
  "/dashboard",
  "/booking",
  "/membership",
  "/profile",
  "/attendance",
  "/users",
  "/settings",
  "/reports",
  "/news/manage",
];

const authPaths = ["/login", "/register"];

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: await headers(),
  });

  const { pathname } = request.nextUrl;

  const isProtected = protectedPaths.some((p) => pathname.startsWith(p));
  if (isProtected && !session) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  const isAuthPage = authPaths.some((p) => pathname === p);
  if (isAuthPage && session) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/dashboard/:path*",
    "/booking/:path*",
    "/membership/:path*",
    "/profile/:path*",
    "/attendance/:path*",
    "/users/:path*",
    "/settings/:path*",
    "/reports/:path*",
    "/news/manage/:path*",
    "/login",
    "/register",
  ],
};
