"use client";

import { subscribe, cancelSubscription } from "@/lib/actions/membership-actions";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { toast } from "sonner";
import { useTransition } from "react";

interface Product {
  id: number;
  name: string;
  description: string | null;
  price: string;
}

interface MembershipActionsProps {
  products: Product[];
  isSubscribed: boolean;
}

export function MembershipActions({
  products,
  isSubscribed,
}: MembershipActionsProps) {
  const [isPending, startTransition] = useTransition();

  function handleSubscribe(productId: number) {
    startTransition(async () => {
      const result = await subscribe(productId);
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Subscription activated successfully!");
      }
    });
  }

  function handleCancel() {
    startTransition(async () => {
      const result = await cancelSubscription();
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Subscription cancelled.");
      }
    });
  }

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold">Available Plans</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {products.map((product) => (
          <Card key={product.id}>
            <CardHeader>
              <CardTitle>{product.name}</CardTitle>
              <CardDescription>{product.description}</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-2xl font-bold">${product.price}</p>
              <Button
                onClick={() => handleSubscribe(product.id)}
                disabled={isPending}
                className="w-full"
              >
                Subscribe
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>

      {isSubscribed && (
        <Button
          variant="destructive"
          onClick={handleCancel}
          disabled={isPending}
        >
          Cancel Subscription
        </Button>
      )}
    </div>
  );
}
