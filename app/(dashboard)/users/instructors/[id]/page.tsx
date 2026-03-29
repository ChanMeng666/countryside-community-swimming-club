import { requireRole } from "@/lib/auth-utils";
import { getInstructorById } from "@/lib/db/queries/user-queries";
import { notFound } from "next/navigation";
import { InstructorEditForm } from "./edit-form";

interface Props {
  params: Promise<{ id: string }>;
}

export default async function InstructorDetailPage({ params }: Props) {
  await requireRole(["manager"]);
  const { id } = await params;
  const instructor = await getInstructorById(Number(id));

  if (!instructor) {
    notFound();
  }

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">
        Edit Instructor: {instructor.title} {instructor.firstName}{" "}
        {instructor.lastName}
      </h1>
      <InstructorEditForm instructor={instructor} />
    </div>
  );
}
