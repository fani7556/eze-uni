import { PrismaClient, Role, AssignmentStatus, PaymentType, ReceiptStatus } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  // Admin, Student, Tutor (operator-managed)
  const admin = await prisma.user.upsert({
    where: { email: "admin@ezeuni.test" },
    update: {},
    create: {
      email: "admin@ezeuni.test",
      username: "admin",
      firstName: "Site",
      lastName: "Admin",
      role: Role.ADMIN,
    },
  });

  const student = await prisma.user.upsert({
    where: { email: "student@ezeuni.test" },
    update: {},
    create: {
      email: "student@ezeuni.test",
      username: "student1",
      firstName: "Ayesha",
      lastName: "Khan",
      role: Role.STUDENT,
      phone: "+92 300 0000000",
    },
  });

  const tutorUser = await prisma.user.upsert({
    where: { email: "tutor@ezeuni.test" },
    update: {},
    create: {
      email: "tutor@ezeuni.test",
      username: "operator1",
      firstName: "Alex",
      lastName: "Morgan",
      role: Role.TUTOR,
    },
  });

  await prisma.tutorProfile.upsert({
    where: { userId: tutorUser.id },
    update: {},
    create: {
      userId: tutorUser.id,
      education: "Masters",
      verified: true,
      online: true,
      subjects: ["Business", "Economics", "Statistics"],
    },
  });

  // Payment modes (admin-configured)
  const pmQR = await prisma.paymentMode.create({
    data: {
      label: "Bank Transfer (QR)",
      type: PaymentType.QR,
      qrUrl: "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=EZE-UNI-PAY",
      accountName: "EZE Uni",
      accountHint: "HBL ****1234",
      email: "pay@ezeuni.com",
      phone: "+92 300 0000000",
      active: true,
    },
  });
  await prisma.paymentMode.create({
    data: { label: "Email Transfer", type: PaymentType.EMAIL, email: "pay@ezeuni.com", active: true },
  });
  await prisma.paymentMode.create({
    data: { label: "Mobile Wallet", type: PaymentType.PHONE, phone: "+92 311 1111111", active: true },
  });

  const now = new Date();
  const days = (n: number) => new Date(now.getTime() + n * 86400000);

  // A1: Work Accepted - Waiting for Payment
  await prisma.assignment.create({
    data: {
      code: "A-1001",
      title: "Network Security Report",
      subject: "Computer Science",
      details: "Write a report on IDS/IPS comparison.",
      dueAt: days(3),
      priceCents: 18000,
      status: AssignmentStatus.WORK_ACCEPTED_WAITING_FOR_PAYMENT,
      acceptedAt: now,
      studentId: student.id,
      tutorId: tutorUser.id,
    },
  });

  // A2: Waiting for Payment Authorization (receipt uploaded; admin must verify)
  await prisma.assignment.create({
    data: {
      code: "A-1002",
      title: "Healthcare Ethics Essay",
      subject: "Nursing",
      details: "1500-word essay on patient consent.",
      dueAt: days(4),
      priceCents: 15000,
      status: AssignmentStatus.WAITING_FOR_PAYMENT_AUTHORIZATION,
      acceptedAt: now,
      paymentSubmittedAt: now,
      studentId: student.id,
      tutorId: tutorUser.id,
      receipts: {
        create: {
          modeId: pmQR.id,
          imageUrl: "https://via.placeholder.com/600x400.png?text=Receipt",
          submittedById: student.id,
          status: ReceiptStatus.SUBMITTED,
          notes: "Paid via QR",
        },
      },
    },
  });

  // A3: In Progress (payment verified)
  await prisma.assignment.create({
    data: {
      code: "A-1003",
      title: "Regression Analysis Case",
      subject: "Statistics",
      details: "OLS with diagnostics.",
      dueAt: days(2),
      priceCents: 22000,
      status: AssignmentStatus.IN_PROGRESS,
      acceptedAt: now,
      paymentSubmittedAt: now,
      paymentVerifiedAt: now,
      startedAt: now,
      studentId: student.id,
      tutorId: tutorUser.id,
      transactions: {
        create: { amountCents: 22000, type: "PAYMENT" },
      },
    },
  });

  // A4: Delivered (auto-complete after 48h later)
  await prisma.assignment.create({
    data: {
      code: "A-1004",
      title: "Operations Strategy Slides",
      subject: "Business",
      details: "10 slides w/ speaker notes.",
      dueAt: days(1),
      priceCents: 12000,
      status: AssignmentStatus.DELIVERED,
      acceptedAt: now,
      paymentSubmittedAt: now,
      paymentVerifiedAt: now,
      startedAt: now,
      deliveredAt: now,
      studentId: student.id,
      tutorId: tutorUser.id,
      transactions: {
        create: { amountCents: 12000, type: "PAYMENT" },
      },
    },
  });

  console.log("Seeded users:", { admin: admin.email, student: student.email, tutor: tutorUser.email });
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });
