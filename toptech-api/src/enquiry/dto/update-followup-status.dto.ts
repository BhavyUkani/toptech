import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateFollowupStatusDto {
  @IsString()
  @IsNotEmpty()
  name: string;
}
