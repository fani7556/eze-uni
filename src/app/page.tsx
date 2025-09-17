export default function Home() {
  return (
    <main className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-black brand-text">EZE Uni</h1>
      <p className="text-slate-600 mt-2">Manual payment authorization • Student / Tutor / Admin</p>
      <div className="mt-6 grid gap-2">
        <a className="underline" href="/student">Student</a>
        <a className="underline" href="/tutor">Tutor</a>
        <a className="underline" href="/admin">Admin</a>
      </div>
    </main>
  );
}
