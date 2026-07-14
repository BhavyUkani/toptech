import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateEnquiryDto {
  @IsString()
  @IsNotEmpty()
  client: string;

  @IsString()
  @IsNotEmpty()
  number: string;

  @IsString()
  @IsNotEmpty()
  product: string;



  @IsString()
  @IsOptional()
  status?: string;

  @IsString()
  @IsOptional()
  date?: string;

  @IsString()
  @IsOptional()
  followups?: string;

  @IsString()
  @IsOptional()
  reminderDate?: string;



  @IsOptional()
  assignedToId?: number;

  @IsOptional()
  assignedById?: number;

  @IsString()
  @IsOptional()
  notes?: string;

  @IsOptional()
  serviceId?: number;
}
