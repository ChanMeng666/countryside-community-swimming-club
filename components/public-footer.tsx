export function PublicFooter() {
  return (
    <footer className="border-t bg-card py-8">
      <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} Countryside Community Swimming Club. All rights reserved.</p>
      </div>
    </footer>
  );
}
