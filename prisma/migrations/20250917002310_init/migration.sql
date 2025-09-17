-- CreateEnum
CREATE TYPE "public"."Role" AS ENUM ('STUDENT', 'TUTOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "public"."AssignmentStatus" AS ENUM ('NOT_ASSIGNED', 'WORK_ACCEPTED_WAITING_FOR_PAYMENT', 'WAITING_FOR_PAYMENT_AUTHORIZATION', 'PAYMENT_VERIFIED', 'IN_PROGRESS', 'DELIVERED', 'COMPLETED', 'DISPUTED', 'CANCELLED', 'OVERDUE');

-- CreateEnum
CREATE TYPE "public"."PaymentType" AS ENUM ('QR', 'EMAIL', 'PHONE');

-- CreateEnum
CREATE TYPE "public"."ReceiptStatus" AS ENUM ('SUBMITTED', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "public"."TicketStatus" AS ENUM ('OPEN', 'PENDING', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "public"."OtpPurpose" AS ENUM ('SIGNUP', 'RESET_PASSWORD', 'LOGIN');

-- CreateTable
CREATE TABLE "public"."User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "phone" TEXT,
    "role" "public"."Role" NOT NULL DEFAULT 'STUDENT',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."TutorProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "education" TEXT,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "online" BOOLEAN NOT NULL DEFAULT false,
    "subjects" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "idCardUrl" TEXT,
    "degreeUrl" TEXT,
    "verifiedAt" TIMESTAMP(3),
    "verifiedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TutorProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Assignment" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "details" TEXT,
    "dueAt" TIMESTAMP(3) NOT NULL,
    "priceCents" INTEGER NOT NULL DEFAULT 0,
    "status" "public"."AssignmentStatus" NOT NULL DEFAULT 'NOT_ASSIGNED',
    "acceptedAt" TIMESTAMP(3),
    "paymentSubmittedAt" TIMESTAMP(3),
    "paymentVerifiedAt" TIMESTAMP(3),
    "startedAt" TIMESTAMP(3),
    "deliveredAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "autoCompletedAt" TIMESTAMP(3),
    "reminder48Sent" BOOLEAN NOT NULL DEFAULT false,
    "reminder24Sent" BOOLEAN NOT NULL DEFAULT false,
    "reminder6Sent" BOOLEAN NOT NULL DEFAULT false,
    "studentId" TEXT NOT NULL,
    "tutorId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Assignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Message" (
    "id" TEXT NOT NULL,
    "assignmentId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "attachmentUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Message_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."PaymentMode" (
    "id" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "type" "public"."PaymentType" NOT NULL,
    "qrUrl" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "accountName" TEXT,
    "accountHint" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentMode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."PaymentReceipt" (
    "id" TEXT NOT NULL,
    "assignmentId" TEXT NOT NULL,
    "modeId" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "submittedById" TEXT NOT NULL,
    "verifiedById" TEXT,
    "status" "public"."ReceiptStatus" NOT NULL DEFAULT 'SUBMITTED',
    "notes" TEXT,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PaymentReceipt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."PaymentTransaction" (
    "id" TEXT NOT NULL,
    "assignmentId" TEXT NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PaymentTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."StudentBankDetail" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accountName" TEXT NOT NULL,
    "bankName" TEXT NOT NULL,
    "ibanOrAcct" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentBankDetail_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."OtpCode" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "destination" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "purpose" "public"."OtpPurpose" NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OtpCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."SupportTicket" (
    "id" TEXT NOT NULL,
    "reporterId" TEXT,
    "assignmentId" TEXT,
    "subject" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "public"."TicketStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SupportTicket_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "public"."User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "public"."User"("username");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "public"."User"("role");

-- CreateIndex
CREATE UNIQUE INDEX "TutorProfile_userId_key" ON "public"."TutorProfile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Assignment_code_key" ON "public"."Assignment"("code");

-- CreateIndex
CREATE INDEX "Assignment_status_dueAt_idx" ON "public"."Assignment"("status", "dueAt");

-- CreateIndex
CREATE INDEX "Assignment_studentId_idx" ON "public"."Assignment"("studentId");

-- CreateIndex
CREATE INDEX "Assignment_tutorId_idx" ON "public"."Assignment"("tutorId");

-- CreateIndex
CREATE INDEX "Message_assignmentId_createdAt_idx" ON "public"."Message"("assignmentId", "createdAt");

-- CreateIndex
CREATE INDEX "PaymentMode_type_active_idx" ON "public"."PaymentMode"("type", "active");

-- CreateIndex
CREATE INDEX "PaymentReceipt_assignmentId_idx" ON "public"."PaymentReceipt"("assignmentId");

-- CreateIndex
CREATE INDEX "PaymentReceipt_status_createdAt_idx" ON "public"."PaymentReceipt"("status", "createdAt");

-- CreateIndex
CREATE INDEX "PaymentTransaction_assignmentId_createdAt_idx" ON "public"."PaymentTransaction"("assignmentId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "StudentBankDetail_userId_key" ON "public"."StudentBankDetail"("userId");

-- CreateIndex
CREATE INDEX "OtpCode_destination_purpose_expiresAt_idx" ON "public"."OtpCode"("destination", "purpose", "expiresAt");

-- CreateIndex
CREATE INDEX "SupportTicket_status_createdAt_idx" ON "public"."SupportTicket"("status", "createdAt");

-- AddForeignKey
ALTER TABLE "public"."TutorProfile" ADD CONSTRAINT "TutorProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Assignment" ADD CONSTRAINT "Assignment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Assignment" ADD CONSTRAINT "Assignment_tutorId_fkey" FOREIGN KEY ("tutorId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Message" ADD CONSTRAINT "Message_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "public"."Assignment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Message" ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PaymentReceipt" ADD CONSTRAINT "PaymentReceipt_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "public"."Assignment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PaymentReceipt" ADD CONSTRAINT "PaymentReceipt_modeId_fkey" FOREIGN KEY ("modeId") REFERENCES "public"."PaymentMode"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PaymentTransaction" ADD CONSTRAINT "PaymentTransaction_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "public"."Assignment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."StudentBankDetail" ADD CONSTRAINT "StudentBankDetail_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SupportTicket" ADD CONSTRAINT "SupportTicket_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SupportTicket" ADD CONSTRAINT "SupportTicket_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "public"."Assignment"("id") ON DELETE SET NULL ON UPDATE CASCADE;
