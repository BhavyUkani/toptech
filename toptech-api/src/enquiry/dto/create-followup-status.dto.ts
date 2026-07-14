import { IsNotEmpty, IsString } from 'class-validator';

export class CreateFollowupStatusDto {
  @IsString()
  @IsNotEmpty()
  name: string;
}
