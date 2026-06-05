export function PublicFooter() {
  return (
    <footer className="border-t bg-card py-8">
      <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} Countryside Community Swimming Club. All rights reserved.</p>

        {/* Developer brand credit — Chan Meng */}
        <div className="mt-6 flex flex-col items-center gap-2 border-t pt-6">
          <a
            href="https://github.com/ChanMeng666"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 text-xs transition-colors hover:text-foreground"
          >
            <img src="/brand/chan-meng-monkey.svg" alt="Chan Meng" className="h-5 w-5" />
            <span className="font-medium">Built by Chan Meng — need a custom app like this one?</span>
          </a>
          <a href="mailto:chanmeng.dev@gmail.com" className="text-xs transition-colors hover:text-foreground">
            chanmeng.dev@gmail.com
          </a>
        </div>
      </div>
    </footer>
  );
}
