import { checkForOverlap } from "@/lib/db/queries/class-queries";
import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  const body = await request.json();
  const { locationId, startTime, endTime, instructorId, excludeClassId } = body;

  const error = await checkForOverlap(
    locationId,
    new Date(startTime),
    new Date(endTime),
    instructorId,
    excludeClassId
  );

  return NextResponse.json({ overlap: !!error, message: error });
}
