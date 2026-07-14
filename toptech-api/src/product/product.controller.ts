import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ProductService } from './product.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Product } from './product.model';

@Controller('products')
@UseGuards(JwtAuthGuard)
export class ProductController {
  constructor(private readonly productService: ProductService) {}

  @Get()
  async findAll() {
    return this.productService.findAll();
  }

  @Post()
  async create(@Body() body: Partial<Product>) {
    return this.productService.create(body);
  }

  @Patch(':id')
  async update(@Param('id') id: number, @Body() body: Partial<Product>) {
    return this.productService.update(id, body);
  }

  @Delete(':id')
  async delete(@Param('id') id: number) {
    await this.productService.delete(id);
    return { success: true };
  }
}
