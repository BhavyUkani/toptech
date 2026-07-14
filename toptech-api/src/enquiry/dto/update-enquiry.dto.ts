import { IsOptional, IsString } from 'class-validator';

export class UpdateEnquiryDto {
  @IsString()
  @IsOptional()
  client?: string;

  @IsString()
  @IsOptional()
  number?: string;

  @IsString()
  @IsOptional()
  product?: string;



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
