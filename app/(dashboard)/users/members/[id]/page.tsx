import { requireRole } from "@/lib/auth-utils";
import { getMemberById } from "@/lib/db/queries/user-queries";
import { notFound } from "next/navigation";
import { MemberEditForm } from "./edit-form";

interface Props {
  params: Promise<{ id: string }>;
}

export default async function MemberDetailPage({ params }: Props) {
  await requireRole(["manager"]);
  const { id } = await params;
  const member = await getMemberById(Number(id));

  if (!member) {
    notFound();
  }

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">
        Edit Member: {member.firstName} {member.lastName}
      </h1>
      <MemberEditForm member={member} />
    </div>
  );
}
